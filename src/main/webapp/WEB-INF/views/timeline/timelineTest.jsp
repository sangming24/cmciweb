<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
    <title>Vis.js Graph</title>
    <script src="<c:url value="/resources/js/vis/vis-timeline-graph2d.min.js"/>" type="text/javascript"></script>
    <link href="<c:url value="/resources/css/vis/vis-timeline-graph2d.min.css"/>" rel="stylesheet" type="text/css"/>
    <script type="module" src="<c:url value='/resources/js/vis/arrow.js' />"></script>
    <script src="<c:url value='/resources/js/customArrow.js' />"></script>
    <style>
        body { font-family: Arial; margin: 20px; }
        #timeline { width: 100%; height: 500px; border: 1px solid lightgray; }
        .context-menu { position: absolute; display: none; background: white; border: 1px solid #ccc; z-index: 1000; }
        .context-menu ul { list-style: none; margin: 0; padding: 5px 0; }
        .context-menu li { padding: 5px 15px; cursor: pointer; }
        .context-menu li:hover { background: #eee; }
        .vis-item.plan   { background: #bbdefb; }
        .vis-item.design { background: #c8e6c9; }
        .vis-item.verify { background: #fff9c4; }
        .vis-item.mass   { background: #ffe0b2; }
        .vis-item.eol    { background: #ef9a9a; }
        .vis-time-axis .vis-text {
            font-size: 10px;
            transform: rotate(-45deg);
            transform-origin: left bottom;
        }
        .vis-item {
          line-height: 14px;      /* 줄 높이 줄이기 */
          padding: 2px 4px;       /* 패딩 조절 */
          font-size: 12px;        /* 글자 크기 줄이기 */
          height: auto !important; /* 높이 자동 */
        }
    #container {
      position: relative;
      width: auto;
      height: 400px;
      border: 1px solid lightgray;
    }
    </style>
</head>
<body>
<h2>Vis.js Timeline</h2>
<p>
    <input id="window1" type="button" value="현재 날짜로 이동(애니메이션)"/>
    <input id="window2" type="button" value="현재 날짜로 이동"/><br/>
    <input id="window3" type="button" value="첫아이템으로 포커스(선택)"/>
    <input id="window4" type="button" value="첫아이템으로 포커스(미선택)"/><br/>
    <input id="window5" type="button" value="모든 아이템 보기"/><br/>
    <input id="window6" type="button" value="선택된 아이템으로 포커스"/><br/>
</p>
<div id="container">
    <div id="timeline"></div>
</div>

<div class="context-menu" id="contextMenu">
    <ul>
        <li id="menuEdit">편집</li>
        <li id="menuDelete">삭제</li>
    </ul>
</div>
<script type="text/javascript">
    const STAGES = [
        { id: 'plan',   order: 0, label: '기획' },
        { id: 'design', order: 1, label: '설계' },
        { id: 'verify', order: 2, label: '검증' },
        { id: 'mass',   order: 3, label: '양산' },
        { id: 'eol',    order: 4, label: '단종' }
    ];

    let timeline = null;

    function getConnections(items) {
        const connections = [];

        items.forEach(item => {
            // 같은 그룹에서 나보다 subgroupOrder 큰 아이템 중 최소
            const nextItem = items
                .filter(i => i.group === item.group && i.subgroupOrder > item.subgroupOrder)
                .sort((a, b) => a.subgroupOrder - b.subgroupOrder)[0];

            if (nextItem) {
                connections.push([item.id, nextItem.id]);
            }
        });

        return connections;
    }

    async function loadTimeline() {
        const contextPath = '<%= request.getContextPath() %>';
        const [groupsResp, itemsResp] = await Promise.all([
            fetch(contextPath + '/resources/data/groups.json'),
            fetch(contextPath + '/resources/data/items.json')
        ]);

        const groupsData = await groupsResp.json();
        const itemsData = await itemsResp.json();

        // vis DataSet 생성
        const groups = new vis.DataSet(groupsData);
        const items = new vis.DataSet(itemsData);

        // Timeline 옵션
        const options = {
            editable: {
                add: true,
                updateTime: true,
                updateGroup: true,
                remove: true
            },
            stack: true,
            margin: { item: 2, axis: 5 },
            multiselect: true,
            zoomMin: 1000 * 60 * 60 * 24,  // 1일
            snap: function(date, scale, step) {
                const snappedDate = new Date(date);
                const minutes = snappedDate.getMinutes();
                snappedDate.setMinutes(minutes - (minutes % 30));
                snappedDate.setSeconds(0);
                snappedDate.setMilliseconds(0);

                return snappedDate;
            },
            //timeAxis: {
            //    scale: "hour",
            //    step: 1
            //},
            onMove: function(item, callback) {
                console.log(`[DB 업데이트 시뮬레이션] 아이템 \${item} 변경됨`, item);
                callback(item);
            },
            onMoving: function (item, callback) {
                callback(item);
            },
            loadingScreenTemplate: function () {
                return "<h1>Loading...</h1>";
            },
            onUpdate: function (item, callback) {
                item.content = prompt('Edit items text:', item.content);
                console.log(item);
                if (item.content != null) {
                    callback(item); // send back adjusted item
                }
                else {
                    callback(null); // cancel updating the item
                }
            },
        };

        const container = document.getElementById('timeline');
        timeline = new vis.Timeline(container, items, groups, { ...options, stack: true });
        const arrows = createArrowManager(timeline, items, itemsData, {color: '#222'});

        const arrowsData = [
            {id: '1to2', id_item_1: 1, id_item_2: 2}
        ]

//        const arrows = new Arrow(timeline, arrowsData);

        requestAnimationFrame(() => {
            timeline.redraw();
        });

        // -----------------------
        // 이벤트 처리
        // -----------------------

        // timeline 변경 시 호출
//        timeline.on('changed', function() {
//            drawDependencies(getConnections(items.get()));
//        });

        // 아이템 선택
        timeline.on('select', function(props) {
            console.log('선택:', props);
            console.log('선택된 아이템:', props.items);
        });

        // 더블클릭
        timeline.on('doubleClick', function(props) {
            console.log('더블 클릭', props)
            const id = props.item;
            if(id) alert(`아이템 \${id} 상세 보기 (PLM 문서 연결 가능)`);
        });

        // 우클릭 컨텍스트 메뉴
        const contextMenu = document.getElementById('contextMenu');

        timeline.on('contextmenu', function(props) {
            props.event.preventDefault();
            if(props.item) {
                // 아이템 우클릭
                contextMenu.style.left = event.pageX + 'px';
                contextMenu.style.top = event.pageY + 'px';
                contextMenu.style.display = 'block';
                contextMenu.dataset.itemId = props.item;

                timeline.setSelection(props.item);
            }
        });
    };

    // -----------------------
    // 버튼 처리
    // -----------------------
    document.getElementById("window1").onclick = function () {
        if(!timeline) return;

        const now = new Date();

        const end = new Date(now);
        end.setDate(end.getDate() + 7);

        timeline.setWindow(now, end);
    };

    document.getElementById("window2").onclick = function () {
        if(!timeline) return;

        const now = new Date();

        const end = new Date(now);
        end.setDate(end.getDate() + 7);

        timeline.setWindow(now, end, {animation: false});
    };

    document.getElementById("window3").onclick = function () {
        if(!timeline) return;

        timeline.setSelection(timeline.itemsData.getIds()[0], {
            focus: true
        })
    };

    document.getElementById("window4").onclick = function () {
        if(!timeline) return;

        timeline.focus(timeline.itemsData.getIds()[0]);
    };

    document.getElementById("window5").onclick = function () {
        if(!timeline) return;

        timeline.fit();
    };

    document.getElementById("window6").onclick = function () {
        if(!timeline) return;

        var arr = timeline.getSelection();

        timeline.focus(arr);
    };

    // 메뉴 클릭
    document.getElementById('menuEdit').onclick = function() {
        const id = contextMenu.dataset.itemId;

        if(id) return;

        console.log('메뉴 클릭', id);
        console.log(contextMenu);
        alert(`아이템 \${id} 편집`);
        contextMenu.style.display = 'none';
    };

    document.getElementById('menuDelete').onclick = function() {
        const id = contextMenu.dataset.itemId;

        if(id) return;

        console.log('메뉴 삭제', id)
        console.log(contextMenu);

        if (confirm('삭제하시겠습니까?')) {
            items.remove(Number(id));
        }
        console.log(`[DB 업데이트 시뮬레이션] 아이템 \${id} 삭제`);
        contextMenu.style.display = 'none';
    };

    // 화면 클릭 시 메뉴 숨기기
    document.addEventListener('click', function() {
        contextMenu.dataset.itemId = "";
        contextMenu.style.display = 'none';
    });

    loadTimeline();


/*
        // -----------------------
        // 화살표 처리
        // -----------------------
        const getItemPos = function(item) {
            left_x = item.left;
            top_y = item.parent.top + item.parent.height - item.top - item.height;
            return {
                left: left_x,
                top: top_y,
                right: left_x + item.width,
                bottom: top_y + item.height,
                mid_x: left_x + item.width / 2,
                mid_y: top_y + item.height / 2,
                width: item.width,
                height: item.height
            };
        }

        function drawArrows(i, j, index) {
            var item_i = getItemPos(timeline.itemSet.items[i]);
            var item_j = getItemPos(timeline.itemSet.items[j]);

            // 직선형 화살표
            // start / end (FS 기준)
            const startX = item_i.right;
            const startY = item_i.mid_y;
            const endX   = item_j.left - 6; // arrowhead 공간
            const endY   = item_j.mid_y;

            let d = "";

            if (Math.abs(startY - endY) < 1) {
                d = `M \${startX} \${startY} L \${endX} \${endY}`
            } else {
                const offsetX = 12;
                const detourX = 8;
                const midY = (startY + endY) / 2;
                const corner = 6;

                d = `
                    M \${startX} \${startY}
                    L \${startX + offsetX} \${startY}
                    L \${startX + offsetX} \${midY}
                    L \${endX - detourX} \${midY}
                    L \${endX - detourX} \${endY}
                    L \${endX} \${endY}
                `;
            }

            dependencyPaths[index].setAttribute("d", d);

            // 일정한 커브 형 화살표
//            var curveLen = item_i.height * 2; // Length of straight Bezier segment out of the item.
//            item_j.left -= 5; // Space for the arrowhead.
//
//            dependencyPaths[index].setAttribute(
//                "d",
//                "M " +
//                item_i.right +
//                " " +
//                item_i.mid_y +
//                " C " +
//                (item_i.right + curveLen) +
//                " " +
//                item_i.mid_y +
//                " " +
//                (item_j.left - curveLen) +
//                " " +
//                item_j.mid_y +
//                " " +
//                item_j.left +
//                " " +
//                item_j.mid_y
//            );
        };

        const drawDependencies = dependency => {
            dependency.map((dep, index) => drawArrows(...dep, index));
          };

        // Create SVG layer on top of timeline "center" div.
        svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.style.position = "absolute";
        svg.style.top = "0px";
        svg.style.height = "100%";
        svg.style.width = "100%";
        svg.style.display = "block";
        svg.style.zIndex = "1"; // Should it be above or below? (1 for above, -1 for below)
        svg.style.pointerEvents = "none"; // To click through, if we decide to put it above other elements.
        timeline.dom.center.appendChild(this.svg);

        // Add arrowhead definition to SVG.
        var arrowHead = document.createElementNS("http://www.w3.org/2000/svg", "marker");
        arrowHead.setAttribute("id", "arrowhead0");
        arrowHead.setAttribute("viewBox", "-10 -5 10 10");
        arrowHead.setAttribute("refX", "-7");
        arrowHead.setAttribute("refY", "0");
        arrowHead.setAttribute("markerUnits", "strokeWidth");
        arrowHead.setAttribute("markerWidth", "3");
        arrowHead.setAttribute("markerHeight", "3");
        arrowHead.setAttribute("orient", "auto");
        var arrowHeadPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
        arrowHeadPath.setAttribute("d", "M 0 0 L -10 -5 L -7.5 0 L -10 5 z");
        arrowHeadPath.style.fill = "#F00";
        arrowHead.appendChild(arrowHeadPath);
        svg.appendChild(arrowHead);

        const dependencyPaths = [];
        for (let i = 0; i < getConnections(items.get()).length; i++) {
            const somePath = document.createElementNS("http://www.w3.org/2000/svg", "path");
            somePath.setAttribute("d", "M 0 0");
            somePath.setAttribute("marker-end", "url(#arrowhead0)");
            somePath.style.stroke = "#F00";
            somePath.style.strokeWidth = "3px";
            somePath.style.fill = "none";
            dependencyPaths.push(somePath);
            svg.appendChild(somePath);
        }
*/
</script>
</body>
</html>

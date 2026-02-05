(function (window) {

    window.createArrowManager = function(timeline, items, itemsData, globalOptions = {}) {
        const options = Object.assign({
            color: '#999',
            strokeWidth: 2,
            arrowSize: 6,
            offset: 12,
            detour: 8
        }, globalOptions);

        const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.style.position = "absolute";
        svg.style.top = "0px";
        svg.style.left = "0px";
        svg.style.height = "100%";
        svg.style.width = "100%";
        svg.style.pointerEvents = "none";
        timeline.dom.center.appendChild(svg);

        // arrowhead 정의
        const defs = document.createElementNS("http://www.w3.org/2000/svg", "defs");
        defs.appendChild(createArrowMarker("arrow_start", "start", options));
        defs.appendChild(createArrowMarker("arrow_end", "end", options));
        svg.appendChild(defs);

        const connections = []; // redraw 대상

        itemsData.forEach(item => {
            if (!item.dependency) return;

            item.dependency.forEach(dep => {
                const depId = typeof dep === 'object' ? dep.id : dep;
                const depOptions = typeof dep === 'object' ? dep : {};

                const fromItem = items.get(item.id);
                const toItem = items.get(Number(depId));

                if (!toItem) return;

                const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
                path.style.fill = "none";
                applyPathStyle(path, Object.assign({}, options, depOptions));
                applyArrowDirection(path, depOptions.direction);

                svg.appendChild(path);

                connections.push({
                    fromItem,
                    toItem,
                    path,
                    options: depOptions
                });
            });
        });

        function createArrowMarker(id, type = "end", options = {}) {
            const marker = document.createElementNS("http://www.w3.org/2000/svg", "marker");
            marker.setAttribute("id", id);
            marker.setAttribute("refY", "0");
            marker.setAttribute("markerUnits", "strokeWidth");
            marker.setAttribute("markerWidth", options.arrowSize);
            marker.setAttribute("markerHeight", options.arrowSize);
            marker.setAttribute("orient", "auto");

            const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
            path.setAttribute("fill", options.color);

            if(type === "start") {
                marker.setAttribute("viewBox", "0 -5 10 10");
                marker.setAttribute("refX", "7");

                path.setAttribute("d", "M 0 0 L 10 -5 L 7.5 0 L 10 5 z");
            } else {
                marker.setAttribute("viewBox", "-10 -5 10 10");
                marker.setAttribute("refX", "-7");

                path.setAttribute("d", "M 0 0 L -10 -5 L -7.5 0 L -10 5 z");
            }

            marker.appendChild(path);
            return marker;
        }

        function applyPathStyle(path, options = {}) {
            if(options.color) path.style.stroke = options.color;
            if(options.strokeWidth) path.style.strokeWidth = options.strokeWidth;

            // 점선 / 대쉬
            if(options.dash) path.style.strokeDasharray = options.dash;
            // 라인 끝 스타일
            if(options.lineCap) path.style.strokeLinecap = options.lineCap; // butt | round | square
            // 라인 조인
            if(options.lineJoin) path.style.strokeLinejoin = options.lineJoin;
        }

        function applyArrowDirection(path, direction = "forward") {
            path.removeAttribute("marker-start");
            path.removeAttribute("marker-end");

            switch (direction) {
                case "forward":
                    path.setAttribute("marker-end", "url(#arrow_end)");
                    break;

                case "backward":
                    path.setAttribute("marker-start", "url(#arrow_start)");
                    break;

                case "both":
                    path.setAttribute("marker-start", "url(#arrow_start)");
                    path.setAttribute("marker-end", "url(#arrow_end)");
                    break;

                default: break;
            }
        }

        function getItemPos(item) {
            const dom = timeline.itemSet.items[item.id];
            const left = dom.left;
            const top = dom.parent.top + dom.parent.height - dom.top - dom.height;

            return {
                left,
                right: left + dom.width,
                top,
                bottom: top + dom.height,
                midX: left + dom.width / 2,
                midY: top + dom.height / 2,
                width: dom.width,
                height: dom.height
            };
        }

        function getAnchors(conn, from, to) {
            const dir = conn.options.direction || "forward";

            if(dir === "backward") {
                return {
                    startX: from.right + 8,
                    startY: from.midY,
                    endX: to.left || 0,
                    endY: to.midY
                }
            }else if(dir === "both") {
                return {
                    startX: from.right + 8,
                    startY: from.midY,
                    endX: to.left - 8,
                    endY: to.midY
                }
            }else{
                return {
                    startX: from.right,
                    startY: from.midY,
                    endX: to.left - 8,
                    endY: to.midY
                }
            }

        }

        function redraw() {
            connections.forEach((conn, index, arr) => {
                const from = getItemPos(conn.fromItem);
                const to = getItemPos(conn.toItem);


                let {startX, startY, endX, endY} = getAnchors(conn, from, to);

                const gap = 6;

                // 출발지 도착지 분산
                const fromSiblings = arr.filter(c => c.fromItem.id === conn.fromItem.id);
                const fromLaneIndex = fromSiblings.findIndex(c => c === conn);
                const fromCount = fromSiblings.length;
                startY += (fromLaneIndex - (fromCount - 1) / 2) * gap

                const toSiblings = arr.filter(c => c.toItem.id === conn.toItem.id);
                const toLaneIndex = toSiblings.findIndex(c => c === conn);
                const toCount = toSiblings.length;
                endY += (toLaneIndex - (toCount - 1) / 2) * gap

                const baseOffset = conn.options.offset || options.offset;
                const offset = baseOffset + fromLaneIndex * 6; // 6px씩 계단

                const baseDetour = conn.options.detour || options.detour;
                const detour = baseDetour + toLaneIndex * 6; // 6px씩 계단
                const midY = (startY + endY) / 2;
                const corner = 6;

                let d = "";

                if (Math.abs(startY - endY) < 1) {
                    d = `M ${startX} ${startY} L ${endX} ${endY}`
                } else {
                    d = `
                        M ${startX} ${startY}
                        L ${startX + offset} ${startY}
                        L ${startX + offset} ${midY}
                        L ${endX - detour} ${midY}
                        L ${endX - detour} ${endY}
                        L ${endX} ${endY}
                    `;
                }

                conn.path.setAttribute("d", d);
            });
        }

        function addDependency(fromId, toId, depOptions = {}) {
            fromId = Number(fromId);
            toId = Number(toId);

            const fromItem = items.get(fromId);
            const toItem = items.get(toId);
            if(!fromItem || !toItem) return;

            // 중복방지
            if (connections.some(c => c.fromItem.id === fromId && c.toItem.id === toId)) return;

            const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
            path.style.fill = "none";
            applyPathStyle(path, Object.assign({}, options, depOptions));
            applyArrowDirection(path, depOptions.direction);

            svg.appendChild(path);

            connections.push({
                fromItem,
                toItem,
                path,
                options: depOptions
            });

            redraw();
        }

        function removeDependency(fromId, toId) {
            fromId = Number(fromId);
            toId = Number(toId);

            const idx = connections.findIndex(c => c.fromItem.id === fromId && c.toItem.id === toId);
            if (idx === -1) return;

            svg.removeChild(connections[idx].path);
            connections.splice(idx, 1);

            redraw();
        }

        timeline.on('changed', redraw);

        return {
            redraw,
            addDependency,
            removeDependency,
            getConnections: () => connections
        }
    }
})(window);

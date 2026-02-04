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
        const arrowHead = document.createElementNS("http://www.w3.org/2000/svg", "marker");
        arrowHead.setAttribute("id", "arrowhead_auto");
        arrowHead.setAttribute("viewBox", "-10 -5 10 10");
        arrowHead.setAttribute("refX", "-7");
        arrowHead.setAttribute("refY", "0");
        arrowHead.setAttribute("markerUnits", "strokeWidth");
        arrowHead.setAttribute("markerWidth", options.arrowSize);
        arrowHead.setAttribute("markerHeight", options.arrowSize);
        arrowHead.setAttribute("orient", "auto");

        var arrowHeadPath = document.createElementNS("http://www.w3.org/2000/svg", "path");
        arrowHeadPath.setAttribute("d", "M 0 0 L -10 -5 L -7.5 0 L -10 5 z");
        arrowHeadPath.setAttribute("fill", options.color);

        arrowHead.appendChild(arrowHeadPath);
        defs.appendChild(arrowHead);
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
                path.setAttribute("marker-end", "url(#arrowhead_auto)");
                path.style.stroke = depOptions.color || options.color;
                path.style.strokeWidth = depOptions.strokeWidth || options.strokeWidth;
                path.style.fill = "none";

                svg.appendChild(path);

                connections.push({
                    fromItem,
                    toItem,
                    path,
                    options: depOptions
                });
            });
        });

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

        function redraw() {
            connections.forEach((conn, index, arr) => {
                const from = getItemPos(conn.fromItem);
                const to = getItemPos(conn.toItem);

                const startX = from.right;
                const startY = from.midY;
                const endX   = to.left - 6; // arrowhead 공간
                const endY   = to.midY;

                // 같은 fromItem끼리 겹치지 않게 offset 계산
                const siblings = arr.filter(c => c.fromItem.id === conn.fromItem.id);
                const laneIndex = siblings.findIndex(c => c === conn);

                const baseOffset = conn.options.offset || options.offset;
                const offset = baseOffset + laneIndex * 6; // 6px씩 계단

                const baseDetour = conn.options.detour || options.detour;
                const detour = baseDetour + laneIndex * 6; // 6px씩 계단
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
            path.setAttribute("marker-end", "url(#arrowhead_auto)");
            path.style.stroke = depOptions.color || options.color;
            path.style.strokeWidth = depOptions.strokeWidth || options.strokeWidth;
            path.style.fill = "none";

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

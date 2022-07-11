import { jsondata } from "/js/paths.js";

const ar_width = 16;
const ar_height = 9;

function getDivSize(classdef) {
    var w = parseInt(classdef.split("-")[2]);
    var h = parseInt(classdef.split("-")[3]);
    return w * h;
}

const parser = new DOMParser();

async function fetchSVG(svg_name) {
    const response = await fetch(svg_name);
    const svgText = await response.text();
    const svgDoc = parser.parseFromString(svgText, 'text/xml');
    return svgDoc;
}

window.onload = function () {

    const current_page = (location.href.split("/").slice(-1)[0]).split(".")[0];
    const paths = jsondata[current_page];

    var styles = getComputedStyle(document.documentElement);
    var grid_columns = styles.getPropertyValue("--grid-columns");
    var grid_rows = Math.round(grid_columns / (ar_width / ar_height) - 1);
    document.documentElement.style.setProperty("--grid-rows", grid_rows);

    var offset = 0;

    // This operation reflects a small cost, so
    // it is ok to iterate here and in later on... for now.

    if (typeof paths !== 'undefined') {
        paths.forEach(path => {
            offset += getDivSize(path.class);
        })
    }

    var matrix_size = grid_columns * grid_rows;
    var matrix_true_size = matrix_size - offset + 2;

    const matrix = document.getElementById("matrix");

    const lightbox = document.createElement("div");
    lightbox.id = "lightbox";
    document.body.appendChild(lightbox);

    lightbox.addEventListener('click', e => {
        lightbox.classList.remove('active');
    })

    for (let i = 0; i < grid_rows; i++) {
        for (let j = 0; j < grid_columns && (i * grid_columns + j <= matrix_true_size); j++) {
            var newDiv = document.createElement("div");
            newDiv.id = i * grid_columns + j;
            newDiv.classList.add("cell");
            // newDiv.innerHTML = newDiv.id;
            matrix.appendChild(newDiv);
        }
    }

    // If we have a paths map, load them in sequence
    // TO DO: Create class module to make this process
    // easier for the developer.

    if (typeof paths !== 'undefined') {
        paths.forEach(path => {
            const pathDiv = document.getElementById(path.id);
            pathDiv.classList.add(path.class);

            if (path.boxtype) {
                pathDiv.classList.add(path.boxtype);
            }

            // We want the image above the main label

            if (path.label) {
                if (path.image && path.label.class == "cell-label-bottom") {
                    const imageDiv = document.createElement("div");
                    fetchSVG("/img/" + path.image).then(imageSVG => {
                        imageDiv.appendChild(imageSVG.documentElement);
                        pathDiv.appendChild(imageDiv);
                    });
                }

                // This is the label. Check to ensure label exists.

                const labelDiv = document.createElement("div");
                labelDiv.classList.add(path.label.class);
                if (path.label.color) {
                    labelDiv.style.color = path.label.color;
                }
                labelDiv.innerHTML = path.label.text;
                pathDiv.appendChild(labelDiv);

                // if we want the image after the main label

                if (path.image && path.label.class == "cell-label-top") {
                    const imageDiv = document.createElement("div");
                    fetchSVG("/img/" + path.image).then(imageSVG => {
                        imageDiv.appendChild(imageSVG.documentElement);
                        pathDiv.appendChild(imageDiv);
                    });
                }
            } else if (path.image) {
                const imageDiv = document.createElement("div");
                imageDiv.id = "svg_" + path.id;
                fetchSVG("/img/" + path.image).then(imageSVG => {
                    imageDiv.appendChild(imageSVG.documentElement);


                    imageDiv.addEventListener('click', e => {
                        lightbox.classList.add('active');
                        const lightboxSVG = document.createElement("div");
                        lightboxSVG.id = "light-box-svg"
                        console.log(lightbox);

                        if (lightbox.firstElementChild) {
                            removeSVGDiv = document.getElementById("light-box-svg");
                            removeSVGDiv.remove()
                        }

                        lightboxSVG.innerHTML = document.getElementById("svg_" + path.id).innerHTML;
                        lightbox.appendChild(lightboxSVG);
                    });


                    pathDiv.appendChild(imageDiv);
                });
            }

            pathDiv.style.setProperty("--splash-delay", path.splash_delay)

            // If we have an overlay modal in the path map

            if (path.modal) {
                const modal = document.getElementById(path.modal);

                pathDiv.addEventListener("mouseover", function () {
                    modal.style.display = "block";
                });

                pathDiv.addEventListener("mouseout", function () {
                    modal.style.display = "none";
                });
            }

            if (path.innerHTML) {
                const innerContent = document.createElement("div");
                const content = path.innerHTML.template;
                fetch(content)
                    .then(r => r.text())
                    .then(t => innerContent.innerHTML = t);
                innerContent.classList.add(path.innerHTML.template_class);
                pathDiv.appendChild(innerContent);
            }

        })
    }
};
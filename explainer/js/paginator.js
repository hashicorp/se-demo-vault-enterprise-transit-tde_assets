/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MPL-2.0
 */

const track_pages = [
    [
        "about-this-track",
        "track-contents",
        "working-environment",
    ],
    [
        "industry-challenges",
        "about-tde",
        "how-ekm-works",
    ],
    [
        "why-enable-tde",
        "dek-key-exchange",
        "configure-tde-mssql",
    ],
    [
        "rotate-dek-kek",
        "compare-before-after",
        "summarize-benefits",
    ]
];

const current_page = (location.href.split("/").slice(-1)[0]).split(".")[0];

var challenge_pages;

function find_section(pageName) {
    track_pages.forEach(section => {
        if (section.indexOf(pageName) !== -1) {
            challenge_pages = section;
        }
    })
}

find_section(current_page);

function isCurrentPage(pageName) {
    return current_page === pageName;
}

function setNextPage(nextPage) {
    const next_page = document.createElement('div');
    const next_url = "/html/" + nextPage + ".html";
    next_page.classList.add("next");
    next_page.addEventListener("click", function () {
        window.location.replace(next_url);
    });
    document.body.appendChild(next_page);
}

function setLastPage(lastPage) {
    const last_page = document.createElement('div');
    const last_url = "/html/" + lastPage + ".html";
    last_page.classList.add("last");
    last_page.addEventListener("click", function () {
        window.location.replace(last_url);
    });
    document.body.appendChild(last_page);
}

for (let i = 0; i < challenge_pages.length; i++) {
    if (isCurrentPage(challenge_pages[i])) {
        if (i == 0 && (i + 1) < challenge_pages.length) {
            setNextPage(challenge_pages[i + 1]);
        } else if (i == (challenge_pages.length - 1) && challenge_pages.length > 1 && i >= 0) {
            setLastPage(challenge_pages[i - 1]);
        } else if (challenge_pages.length > 1) {
            setNextPage(challenge_pages[i + 1]);
            setLastPage(challenge_pages[i - 1]);
        }
    }
}
let config;
let pre_auth_path = '', restored_path = false;
let results_frame, search_form, search_field, search_button, open_link, copy_link, search_icon, search_spinner;

// Change these to the right index and domain
const KIBANA_PATH = "/kibana"
const DISCOVER_PATH = KIBANA_PATH + "/app/discover"
const VIEW_PATH = "/view/"

const DEFAULT_PATH = () => `#/?_a=(index:'${config.index_pattern_id}')&embed=true`

function loadConfig() {
    $.get("/api/config")
        .done(function (data) {
            config = data;
            search_button.prop("disabled", false);
            search_field.prop("disabled", false)

            if (!restored_path) {
                results_frame[0].src = DISCOVER_PATH + DEFAULT_PATH()
            }
        })
        .fail(function(e) {
            console.error(e);
            alert("Failed to retrieve config from API");
        })
}

function getNonEmbedUrl() {
    return results_frame[0].src.replace("&embed=true", "")
        .replace("?embed=true&", '?')
        .replace("?embed=true", "");
}

function displayKibanaFrame(search_id) {
    let url = `${DISCOVER_PATH}#${VIEW_PATH}${search_id}?embed=true`
    results_frame[0].src = url
    search_spinner.hide();
    search_icon.show();
}

function doSearch(queryText) {
    $.ajax("/api/search", {
        data: JSON.stringify({ query: queryText}),
        type: 'POST',
        contentType: 'application/json',
        dataType: "json"
        })
        .done(function (data) {
            displayKibanaFrame(data.saved_search_id)
        })
        .fail(function (e) {
            console.error(e)
            alert("Failed to retrieve search")
        })
}

$(function() {
    results_frame = $("#results_frame");
    search_form = $("#search_form");
    search_field = $("#search_field");
    open_link = $("#open_link");
    copy_link = $("#copy_link");
    search_icon = $("#search_icon");
    search_spinner = $("#search_spinner");
    search_button = $("#search_button");

    search_field.prop("disabled", true)
    search_button.prop("disabled", true)
    loadConfig();

    var params = new URLSearchParams(window.location.hash.slice(1));

    var queryProxy = new Proxy(new URLSearchParams(window.location.hash.slice(1)), {
        get: (searchParams, prop) => searchParams.get(prop),
    });

    console.log(params)

    if (queryProxy.return_to !== null) {
        console.log("return to url detected")
        let return_url = new URL(queryProxy.return_to, window.location);
        if (return_url.host === window.location.host && return_url.pathname.startsWith(KIBANA_PATH)) {
            console.log("going to url")
            results_frame[0].src = decodeURI(queryProxy.return_to);
            restored_path = true;
            window.location.hash = "";
        }
    }

    search_form.submit(function(e) {
        e.preventDefault();
        console.log("Submit action running");
        search_icon.hide();
        search_spinner.show();
        var query = search_field.val();

        doSearch(query);

        return false;
    });

    open_link.click(function(e) {
        e.preventDefault();

        window.open(getNonEmbedUrl());
    })

    results_frame.on('load', function (e) {
        if (e.target.contentWindow.location.pathname.startsWith('/auth/login')) {
            let targetUrl = window.location.pathname + '#return_to=' + encodeURIComponent(pre_auth_path);
            window.location = '/auth/login?redirect_url=' + encodeURIComponent(targetUrl)
        } else {
            pre_auth_path = e.target.contentWindow.location.pathname;
        }
    })

    new ClipboardJS('#copy_link', {
        text: function (trigger) {
            return getNonEmbedUrl()
        },
    });
});
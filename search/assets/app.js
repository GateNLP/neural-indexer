let config;
let results_frame, search_form, search_field, search_button, open_link, copy_link, search_icon, search_spinner;

// Change these to the right index and domain
const DISCOVER_PATH = "/app/discover"
const VIEW_PATH = "/view/"

const DEFAULT_PATH = () => `#/?_a=(index:'${config.index_pattern_id}')&embed=true`

function loadConfig() {
    $.get("/api/config")
        .done(function (data) {
            config = data;
            search_button.prop("disabled", false);
            search_field.prop("disabled", false)
            results_frame[0].src = config.kibana_root + DISCOVER_PATH + DEFAULT_PATH()
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
    let url = `${config.kibana_root}${DISCOVER_PATH}#${VIEW_PATH}${search_id}?embed=true`
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

    new ClipboardJS('#copy_link', {
        text: function (trigger) {
            return getNonEmbedUrl()
        },
    });
});
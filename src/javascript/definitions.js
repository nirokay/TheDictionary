const searchBarId = "search-bar-field";

function getSearchBar() {
    return document.getElementById(searchBarId);
}

function getQueryParams() {
    let searchBar = getSearchBar();
    if(searchBar == undefined) {
        return undefined;
    }
    return encodeURI(searchBar.value);
}

function searchBarQuery() {
    let query = getQueryParams();
    if(query == undefined) {
        return alert("Fuck you");
    }

    if(query != "") {
        query = "%" + query + "%";
    }

    window.location = "/definitions/" + query;
}

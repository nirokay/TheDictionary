const searchBarId = "search-bar-field";

function getSearchBar() {
    return document.getElementById(searchBarId);
}

function getQueryParams() {
    let searchBar = getSearchBar();
    if(searchBar == undefined || searchBar == null) {
        return undefined;
    }
    return encodeURI(searchBar.value);
}

function searchBarQuery() {
    let query = getQueryParams();
    if(query == undefined) {
        return alert("Cannot search, fuck you javascript");
    }

    if(query != "") {
        query = "%" + query + "%";
    }

    window.location = "/definitions/" + query;
}

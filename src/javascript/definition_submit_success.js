function redirect() {
    window.location.replace("/definitions")
}

window.onload = function() {
    setTimeout(redirect, 3000);
}

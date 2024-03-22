const contentDiv = "content-display-div";
const submitWordId = "submit-word";
const submitDefinitionId = "submit-definition";
const submitAuthorId = "submit-author";


function renderForm() {
    document.getElementById(contentDiv).innerHTML = `
        <form action="/handle-submit" method="post">
            <ul>
                <li>
                    <label for="submit-word">Word:</label>
                    <br />
                    <input type="text" id="submit-word" name="submit-word" />
                </li>
                <li>
                    <label for="submit-author">Author: (optional)</label>
                    <br />
                    <input type="text" id="submit-author" name="submit-author" />
                </li>
                <li>
                    <label for="submit-definition">Definition:</label>
                    <br />
                    <textarea id="submit-definition" name="submit-definition"></textarea>
                </li>
            </ul>
            </form>
        <button onclick="submitFormButtonPress()">Submit</button>
    `;
}

function cleanUpString(str) {
    let result = str;
    console.log(result)
    if(result === undefined || result === null) {
        return "";
    }
    console.log(result)
    result.replace("<", "&lt;").replace(">", "&gt;")
    console.log(result)
    return result;
}

function submitFormButtonPress() {
    let word = document.getElementById("submit-word").value;
    let definition = document.getElementById("submit-definition").value;
    let author = document.getElementById("submit-author").value;
    let json = JSON.stringify({
        "word": cleanUpString(word),
        "definition": cleanUpString(definition),
        "author": cleanUpString(author)
    })
    let encoded = btoa(json)
    let host = window.location.hostname
    console.log(json)
    window.location.replace("/submit/" + encoded)
}

window.onload = function() {
    renderForm();
}

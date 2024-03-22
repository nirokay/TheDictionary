const contentDiv = "content-display-div";
const submitWordId = "submit-word";
const submitDefinitionId = "submit-definition";
const submitAuthorId = "submit-author";


function renderForm() {
    document.getElementById(contentDiv).innerHTML = `
        <form action="/handle-submit" method="post" class="center">
            <ul>
                <li>
                    <label for="submit-word">Word:</label>
                    <br />
                    <input type="text" id="submit-word" name="submit-word" placeholder="My interesting word" />
                </li>
                <li>
                    <label for="submit-definition">Definition:</label>
                    <br />
                    <textarea id="submit-definition" name="submit-definition" rows="10" placeholder="My interesting definition" ></textarea>
                </li>
                <li>
                    <label for="submit-author">Author: (optional)</label>
                    <br />
                    <input type="text" id="submit-author" name="submit-author" placeholder="My name (optional)" />
                </li>
            </ul>
        </form>
        <div class="center-everything">
            <button onclick="submitFormButtonPress();">Submit</button>
        </div>
    `;
}

function cleanUpString(str) {
    let result = str;
    if(result === undefined || result === null) {
        return "";
    }
    // result.replace("<", "&lt;").replace(">", "&gt;")
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
    try {
        let encoded = btoa(json)
        window.location.replace("/submit/" + encoded)
    } catch {
        alert("Your submission seems to use Base64 unsupported characters. Please replace them with supported ones :(")
    }
}

window.onload = function() {
    renderForm();
}

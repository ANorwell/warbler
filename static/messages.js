
const topic = (new URLSearchParams(window.location.search)).get('topic') || 'chat';
const baseUrl = `https://3nxef8f9d7.execute-api.us-east-2.amazonaws.com/test/${topic}`;

// based closely on https://stackoverflow.com/questions/30008114/how-do-i-promisify-native-xhr
function makeRequest(method, url, bodyObject = null) {
  return new Promise(function (resolve, reject) {
    let xhr = new XMLHttpRequest();
    xhr.open(method, url);
    xhr.onload = function () {
      if (this.status >= 200 && this.status < 300) {
        resolve(xhr.response);
      } else {
        reject({ status: this.status });
      }
    };
    xhr.onerror = function () {
      reject({ status: this.status });
    }
    
    if (bodyObject) {
      xhr.send(JSON.stringify(bodyObject));
    } else {
      xhr.send();
    }
  });
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function getMessages() {
  let response = await makeRequest('GET', baseUrl);
  console.log(response);
  return JSON.parse(response).Messages;
}

async function loadMessages() {
  const messages = await getMessages();
  document.getElementById('messages').innerHTML = '';
  messages.forEach(message => renderMessage(message));
}

customElements.define('message-item',
  class extends HTMLElement {
    constructor() {
      super();
      const template = document
        .getElementById('message-template')
        .content;
      const shadowRoot = this.attachShadow({mode: 'open'})
        .appendChild(template.cloneNode(true));
  }
});

function renderMessage(message) {
  const minAgo = (Date.now() - message.Timestamp)/60000;

  let time = "A few seconds ago";

  if (minAgo >= 2) {
    time = `${Math.floor(minAgo)} minutes ago`;
  } else if (minAgo >= 1) {
    time = 'One minute ago';
  }


  const html = `
  <message-item>
    <span slot=author>
      <span style="color:${colorize(message.User)}">
      ${message.User}
      </span>
    </span>
    <span slot=time>${time}</span>
    <span slot=message>${message.Message}</span>
  </message-item>`;

  const parent = document.getElementById('messages');
  parent.insertAdjacentHTML("beforeend", html);
};


async function submitPost(e) {
  e.preventDefault();
  const form = document.forms['submit-post'];
  const payload = {
    User: form.User.value,
    Message: form.Message.value
  };

  let result = await makeRequest('POST', baseUrl, payload);
  console.log('Submitted message: ', payload);
  
  await delay(100); // allow time for the message to be readable
  await loadMessages();
  return result;
}

function colorize(user) {
  const colors = [
    "rgb(122, 33, 204)",
    "rgb(44, 84, 156)",
    "rgb(191, 108, 5)",
    "rgb(25, 125, 93)"
  ];

  // https://stackoverflow.com/questions/7616461/generate-a-hash-from-string-in-javascript
  let hash = 0, i, chr;
  for (i = 0; i < user.length; i++) {
    chr   = user.charCodeAt(i);
    hash  = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return colors[Math.abs(hash) % colors.length];  


}

document.getElementById('submit-post').onsubmit = submitPost;
loadMessages();

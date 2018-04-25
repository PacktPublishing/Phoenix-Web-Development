// Push the vote up to the server
const pushVote = (el, channel) => {
  channel
    .push("vote", { option_id: el.getAttribute("data-option-id") })
    .receive("ok", res => console.log("You Voted!"))
    .receive("error", res => console.log("Failed to vote:", res));
};

// When we join the channel, do this
const onJoin = (res, channel) => {
  document.querySelectorAll(".vote-button-manual").forEach(el => {
    el.addEventListener("click", event => {
      event.preventDefault();
      pushVote(el, channel);
    });
  });
  console.log("Joined channel:", res);
};

const connect = socket => {
  // Only connect to the socket if the polls channel actually exists!
  const enableLivePolls = document.getElementById("enable-polls-channel");
  if (!enableLivePolls) {
    return;
  }

  // Pull the Poll Id to find the right topic from the data attribute
  const pollId = enableLivePolls.getAttribute("data-poll-id");
  // Get the stored remote IP for a user
  const remoteIp = document
    .getElementsByName("remote_ip")[0]
    .getAttribute("content");
  // Create a channel to handle joining/sending/receiving
  const channel = socket.channel("polls:" + pollId, { remote_ip: remoteIp });

  // Next, join the topic on the channel!
  channel
    .join()
    .receive("ok", res => onJoin(res, channel))
    .receive("error", res => console.log("Failed to join channel:", res));

  document.getElementById("polls-ping").addEventListener("click", () => {
    channel
      .push("ping")
      .receive("ok", res => console.log("Received PING response:", res.message))
      .receive("error", res => console.log("Error sending PING:", res));
  });

  channel.on("pong", payload => {
    console.log("The server has been PONG'd and all is well:", payload);
  });

  channel.on("new_vote", ({ option_id, votes }) => {
    document.getElementById("vote-count-" + option_id).innerHTML = votes;
  });
};

export default { connect };

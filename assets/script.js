let counter = -1;

async function setCounter() {
  let response = await fetch(
    "https://edlde31iu3.execute-api.us-east-1.amazonaws.com/Prod/set_counter",
    {
      method: "POST",
    }
  );
  let data = await response.json();
}

async function getCounter() {
  try {
    let response = await fetch(
      "https://edlde31iu3.execute-api.us-east-1.amazonaws.com/Prod/get_counter"
    );
    if (!response.ok) {
      throw Error("No items found");
    }
    let data = await response.json();
    counter = data.value;
    document.querySelector(
      "#counter"
    ).innerHTML = `Hey! This page has been loaded ${counter} times in total by people around the world.`;
    setCounter();
  } catch (err) {
    console.log(err);
  }
}

getCounter();

function get_optional(context) {
  if (context.future().text !== '[')
    return null;
  context.expandNextToken();
  let argument = '';
  let token = context.expandNextToken();
  while (token.text !== ']' && token.text !== 'EOF') {
    argument += token.text;
    token = context.expandNextToken();
  }
  return argument;
}

function katze_optional_command(name, default_arg) {
  return (context) => {
    const optional = get_optional(context);
    return name + "{" + (optional === null ? default_arg : optional) + "}";
  };
}

function random_string(length) {
  const alphabets = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const nalpha = alphabets.length;
  const chars = [];
  for (let i = 0; i < length; i++) {
    const index = Math.floor(nalpha * Math.random());
    chars.push(alphabets[index]);
  }
  return chars.join("");
}

function katze_macros(macros) {
  const expansions = {};
  Object.entries(macros).forEach(([name, definition]) => {
    // TODO: deal with allow_par properly
    if (!definition.has_optional) {
      expansions[name] = definition.body;
    }
    else {
      const internal_name = name + random_string(20);
      expansions[name] = katze_optional_command(internal_name, definition.opt_default);
      expansions[internal_name] = definition.body;
    }
  });
  return expansions;
}

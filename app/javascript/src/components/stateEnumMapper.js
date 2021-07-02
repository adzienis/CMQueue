export default (state) => {
  switch (state) {
    case 0:
      return "unresolved";
    case 1:
      return "resolving";
    case 2:
      return "resolved";
    case 3:
      return "frozen";
    case 4:
      return "kicked";
  }
};

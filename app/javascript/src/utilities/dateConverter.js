export function convertToDate(date) {
  const offset = date.getTimezoneOffset();
  const new_date = new Date(date.getTime() - offset * 60 * 1000);
  return new_date.toISOString().split("T")[0];
}

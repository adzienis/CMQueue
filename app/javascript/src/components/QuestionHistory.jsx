import React from "react";
import { useQuery } from "react-query";

export default (props) => {
  const { question } = props;

  const { data: question_states } = useQuery([
    "questions",
    question?.id,
    "question_states",
  ]);
  const { data: previous_questions } = useQuery([
    "questions",
    question?.id,
    "previousQuestions",
  ]);

  return <></>;
};

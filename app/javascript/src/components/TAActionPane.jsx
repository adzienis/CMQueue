import React, { useContext } from "react";
import QuestionAnswerer from "./QuestionAnswererButton";
import QueueOpener from "./QueueOpener";
import Select, { components } from "react-select";
import { useQuery } from "react-query";
import UserContext from "../context/UserContext";
import TALog from "./TALog";

const Option = (props) => {
  const { groupedTags } = props.selectProps;

  let badgeValue;

  if (groupedTags && props.value in groupedTags) {
    badgeValue = groupedTags[props.value];
  } else {
    badgeValue = 0;
  }

  return (
    <div className="d-flex">
      <div className="d-flex justify-content-center align-items-center">
        <div className="badge bg-secondary">{badgeValue}</div>
      </div>
      <components.Option {...props} />
    </div>
  );
};

export default (props) => {
  const { courseId, userId, enrollmentId } = props;

  const { data: tags } = useQuery([
    "tags",
    "?",
    `course_id=${courseId}`,
    "archived=false",
  ]);
  const { data: groupedTags } = useQuery([
    "grouped_tags",
    "?",
    `course_id=${courseId}`,
    `state=${JSON.stringify(["unresolved", "frozen"])}`,
  ]);

  const { selectedTags, setSelectedTags } = useContext(UserContext);

  return (
    <div className="mb-4">
      <div className="d-flex mb-4">
        <div
          className="w-100"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
            gridGap: "10px",
          }}
        >
          <QuestionAnswerer
            userId={userId}
            courseId={courseId}
            enrollmentId={enrollmentId}
          />
          <QueueOpener userId={userId} courseId={courseId} />
        </div>
      </div>
      <div>
        <label className="fw-bold">Filter Questions by Tag</label>
        <Select
          groupedTags={groupedTags}
          components={{ Option }}
          placeholder="Select a Tag to Filter Questions"
          isMulti
          onChange={(data) => {
            const mapped = data.map((tag) =>
              tags.find((otherTag) => otherTag.id === tag.value)
            );

            setSelectedTags(mapped);
          }}
          value={selectedTags.map((tag) => ({
            value: tag.id,
            label: tag.name,
          }))}
          options={tags
            ?.filter((tag) => {
              const pair = Object.entries(groupedTags || [])?.find(
                ([k, v]) => parseInt(k, 10) === tag.id
              );
              if (typeof pair !== "undefined") {
                return pair[1] > 0;
              }
            })
            .map((tag) => ({
              value: tag.id,
              label: tag.name,
            }))}
        />
      </div>
    </div>
  );
};

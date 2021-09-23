import React, { useEffect, useRef, useState } from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import CourseCard from "./CourseCard";
import AsyncSelect from "react-select/async";
import Select from "react-select";
import { useForm, Controller } from "react-hook-form";
import defaultMutationFn from "../utilities/defaultMutationFn";
import { ErrorMessage } from "@hookform/error-message";
import SearchModal from "./SearchModal";

export default (props) => {
  const { userId } = props;
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const { data } = useQuery(["courses", "?", `name=${search}`], {
    select: (data) => {
      return data.map((v) => ({ label: v.name, value: v.id }));
    },
  });

  const { data: enrollments } = useQuery([
    "users",
    parseInt(userId, 10),
    "enrollments",
    "?",
    "role=student",
  ]);

  return (
    <>
      {open && <SearchModal />}
      <div
        style={{ display: "grid", gridTemplateColumns: "1fr", rowGap: "1rem" }}
      >
        <a
          href=""
          className="card shadow-sm hover-container"
          onClick={(e) => {
            e.preventDefault();
            setOpen(true);
          }}
        >
          <div
            className="card-body"
            style={{ display: "flex", justifyContent: "center" }}
          >
            <div className="d-flex flex-column justify-content-center align-items-center">
              <i className="fas fa-plus fa-2x text-primary" />
              <div> Add a Course </div>
            </div>
          </div>
        </a>
        {enrollments?.map((v) => (
          <CourseCard enrollment={v} />
        ))}
      </div>
    </>
  );
};

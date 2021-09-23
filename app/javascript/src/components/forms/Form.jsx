import { useForm } from "react-hook-form";

export default (props) => {
  const {
    register,
    handleSubmit,
    watch,
    control,
    setError,
    clearErrors,
    reset,

    formState: { errors: formErrors },
  } = useForm();

  return null;
};

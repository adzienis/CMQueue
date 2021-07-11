import React from 'react'
import Select from 'react-select'

export const SelectField = ({options, field, form, isMulti}) => (
    <Select
        isMulti={isMulti}
        options={options}
        name={field.name}
        value={isMulti ? options?.filter(option => field?.value?.includes(option.value)) : ''}
        onChange={(option) => form.setFieldValue(field.name, isMulti ? option.map(v => v.value) : option.value)
        }
        onBlur={field.onBlur}
    />
)
import React from 'react'
import Select from 'react-select'

export const SelectField = ({options, field, form, isMulti}) => (
    <Select
        isMulti={isMulti}
        options={options}
        name={field.name}
        value={options ? options.find(option => option.value === field.value) : ''}
        onChange={(option) => form.setFieldValue(field.name, isMulti ? option.map(v => v.value) : option.value)
        }
        onBlur={field.onBlur}
    />
)
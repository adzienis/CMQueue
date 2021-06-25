import React from 'react'

export default props => {

    const {title, value, icon, loading} = props;


    return (
        <div className='card bg-white' style={{height: '120px', maxHeight: '120px'}}>
            <div className='card-body d-flex flex-row'>
                {
                    loading ?
                        (
                            <div className="d-flex justify-content-center align-items-center w-100">
                                <div className="spinner-border" role="status">
                                    <span className="visually-hidden">Loading...</span>
                                </div>
                            </div>
                        )
                        : (
                            <>
                                {icon}
                                <div>
                                    <div className='card-title mb-1'>
                                        <b>
                                            {title}
                                        </b>
                                    </div>
                                    <div className='card-text'>
                                        <p className='h2 text-secondary'>
                                            {value}
                                        </p>
                                    </div>
                                </div>
                            </>
                        )
                }
            </div>
        </div>
    )
}
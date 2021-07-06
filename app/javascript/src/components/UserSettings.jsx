import ReactDOM from "react-dom";
import {QueryClientProvider, useQuery} from "react-query";
import React, {useEffect} from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";

const wrappedFetch = async (url, options) => {
    const token = document
        .querySelector("meta[name='csrf-token']")
        .getAttribute("content");

    return await fetch(url, {
        ...options,
        headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-CSRF-Token": token,
            ...(options.headers ? options.headers : {})
        },
    })
}

const handle_permission = async (setting_id, checked) => {

    if (checked) {
        if (!("Notification" in window)) {
            console.log("This browser does not support desktop notification");
        } else if (Notification.permission === "granted") {

            await wrappedFetch(`/settings/${setting_id}?`, {
                method: 'PATCH',
                credentials: "include",
                body: JSON.stringify({[setting_id]: "true"})
            })
        } else {
            return Notification.requestPermission().then(async function (permission) {


                if (permission === "granted") {


                    await wrappedFetch(`/settings/${setting_id}?`, {
                        method: 'PATCH',
                        credentials: "include",
                        body: JSON.stringify({[setting_id]: "true"})
                    })


                } else if (permission === "denied") {

                    alert("Permission denied, please enable notifications in your browser; then try again.")

                    return Promise.reject("err")


                    await wrappedFetch(`/settings/${setting_id}?`, {
                        method: 'PATCH',
                        credentials: "include",
                        body: JSON.stringify({[setting_id]: "false"})
                    })
                }
            })
        }
    } else {


        await wrappedFetch(`/settings/${setting_id}?`, {
            method: 'PATCH',
            credentials: "include",
            body: JSON.stringify({[setting_id]: "false"})
        })
    }
}


export default props => {
    const {settings: settingsPlaceholder, userId} = props;

    const {data: settings} = useQuery(['settings', '?', `user_id=${userId}`], {
        placeholderData: settingsPlaceholder
    })

    const {mutate: changeSetting} = useWrappedMutation(
        ({id, value}) => ({
            [id]: value,
            url: `/settings/${id}`
        }),
        null,
        {
            method: "PATCH"
        }
    );

    useEffect(async () => {
        if (Notification.permission === "default") {
            const token = document
                .querySelector("meta[name='csrf-token']")
                .getAttribute("content");


            await fetch(`/settings/${settings.find(k => k.key === "Desktop_Notifications").id}?`, {
                method: 'PATCH',
                credentials: "include",
                headers: {
                    "Accept": "application/json",
                    "Content-Type": "application/json",
                    "X-CSRF-Token": token,
                },
                body: JSON.stringify({[settings.find(k => k.key === "Desktop_Notifications").id]: "false"})
            })
        }

    }, [Notification.permission])

    return <ul className="list-group">
        {settings.sort((l, r) => l.id - r.id).map(v => {

            if (v.key === "Desktop_Notifications") {
                return (
                    <li className="list-group-item d-flex justify-content-between align-items-center">
                        <div className="form-check form-switch" key={v.id}>
                            <label className="form-check-label"> Desktop Notifications </label>
                            <input
                                type="checkbox"
                                className="form-check-input"
                                checked={v.value === "true"}
                                onClick={async e => {
                                    await handle_permission(v.id, e.target.checked)
                                    try {
                                    } catch (err) {
                                        console.log('caught error')
                                        e.target.checked = false;
                                    }
                                }
                                }
                            />
                        </div>
                    </li>
                )
            }

            switch (v.setting_type) {
                case "boolean":
                    return (
                        <li className="list-group-item d-flex justify-content-between align-items-center">
                            <div className="form-check form-switch" key={v.id}>
                                <label className="form-check-label"> {v.key} </label>
                                <input
                                    type="checkbox"
                                    className="form-check-input"
                                    onClick={e => {
                                        try {
                                            changeSetting({id: v.id, value: `${e.target.checked}`})
                                        } catch (err) {

                                        }
                                    }
                                    }
                                    checked={v.value === "true"}
                                />
                            </div>
                        </li>
                    )
                    break;
            }
        })}
    </ul>
}
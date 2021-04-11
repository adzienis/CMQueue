// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useState} from 'react'
import ReactDOM from 'react-dom'
import {Button, Modal, Search} from 'semantic-ui-react'
import {QueryClient, QueryClientProvider, useQuery} from "react-query";
import queryClient from "./queryClientFile";


const Hello = props => {

    const [open, setOpen] = useState(false);
    const [search, setSearch] = useState(null);

    const {data, isLoading, isFetching} = useQuery(['courseSearch', search], () => fetch(`/courses/search?name=${search}`, {
        headers: {
            'Accept': 'application/json'
        }
    }).then(resp => resp.json()).then(json => json.map(v => ({title: v.name, id: v.id}))))

    console.log(data, isLoading)


    return (<Modal
        id='fooo'
        onClose={() => setOpen(false)}
        onOpen={() => setOpen(true)}
        open={open}
        trigger={<Button> Show Modal</Button>}
    >
        <Modal.Header>
            Course Search
        </Modal.Header>
        <Modal.Content>
            <Search
                loading={isLoading || isFetching}
                results={data}
                onSearchChange={(e, data) => setSearch(data.value)}
            />
        </Modal.Content>
    </Modal>)
}

document.addEventListener(
    'DOMContentLoaded',
    () => {
        const node = document.getElementById('hello-react')
        const data = JSON.parse(node.getAttribute('data'))
        const children = node.children;
            console.log('qweqwew')
            ReactDOM.render(<QueryClientProvider client={queryClient}><Hello /></QueryClientProvider>, node)
    }
);

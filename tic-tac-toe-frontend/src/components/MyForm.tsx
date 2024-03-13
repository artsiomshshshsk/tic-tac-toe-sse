import {ChangeEvent, FormEvent, useState} from "react";

interface Props {
    onSubmit: (val: string) => void;
}
function MyForm({onSubmit}: Props) {
    const [inputValue, setInputValue] = useState('');

    const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        onSubmit(inputValue);
        setInputValue('');
    };

    const handleInputChange = (event: ChangeEvent<HTMLInputElement>) => {
        setInputValue(event.target.value);
    };

    return (
        <form onSubmit={handleSubmit} className={'my-form'}>
            <input
                type="text"
                value={inputValue}
                onChange={handleInputChange}
            />
            <button className={'my-button'} type="submit">Submit</button>
        </form>
    );
}


export default MyForm;
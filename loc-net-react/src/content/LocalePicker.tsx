import { ChangeEvent, useState } from "react"
import { LocaleModel } from "../services/model"

type Props = {
    locales: LocaleModel[],
    defaultCode: string,
    handleChange: (localeCode: string) => void
}

export default function LocalePicker({ locales, defaultCode, handleChange }: Props) {

    const [selection, setSelection] = useState(defaultCode);

    function onChange(event: ChangeEvent<HTMLSelectElement>) {
        const selectElement = event.target;
        const localeCode = selectElement.value;
        setSelection(localeCode);
        handleChange(localeCode);
    }

    return <select value={selection} onChange={onChange}>
        {locales.map((l) =>
            <option key={l.code} value={l.code}>
                {l.code}
            </option>
        )}
    </select>
}

export type ProjectModel = {
    id: string,
    name: string
}

export type LocaleModel = {
    id: string,
    code: string
}

export type EntryModel = {
    id: string,
    key: string,
    keyId: string,
    locale: string
    value: string
}

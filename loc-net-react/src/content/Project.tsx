import { useSuspenseQuery } from "@tanstack/react-query";
import { useAuth } from "../auth/AuthProvider";
import { LocaleModel, ProjectModel } from "../services/model";
import { API_URL } from "../services/api";
import LocalePicker from "./LocalePicker";
import Entries from "./Entries";
import { Suspense, useEffect, useState } from "react";

type Props = {
    project: ProjectModel
}

export default function Project({ project }: Props) {
    const [localeCode, setLocaleCode] = useState<string | undefined>();
    const { authorizedFetch } = useAuth();
    const localesQuery = useSuspenseQuery({
        queryKey: ["project-locales-query"],
        retry: false,
        staleTime: 1000,
        queryFn: async (): Promise<LocaleModel[]> => {
            console.log("loading projects");
            const fetchedlocales: LocaleModel[] = await authorizedFetch(new Request(API_URL + "/projects/" + project.id + "/locales"));
            return fetchedlocales;
        }
    })

    function defaultSelection(locales: LocaleModel[]) {
        let ind = locales.findIndex(l => l.code == "en");
        if (ind === -1) ind = locales.findIndex(l => l.code.startsWith("en"));
        if (ind === -1) ind = 0;
        return locales[ind].code;
    }

    function localeChange(localeCode: string) {
        console.log(localeCode);
        setLocaleCode(localeCode);
    }

    const locales = localesQuery.data;

    useEffect(() => {
        setLocaleCode(defaultSelection(locales))
    }, [locales]);

    if (!localeCode) return <></>

    return <>
        <p>
            Project: {project.name} {project.id}
        </p>
        <LocalePicker locales={locales} defaultCode={localeCode} handleChange={localeChange} />
        <Suspense fallback={<>Loading...</>}>
            <Entries projectId={project.id} localeCode={localeCode} />
        </Suspense>
    </>
}

import { useSuspenseQuery } from "@tanstack/react-query";
import { useAuth } from "../auth/AuthProvider";
import { EntryModel } from "../services/model";
import { API_URL } from "../services/api";

type Props = {
    projectId: string,
    localeCode: string
}

export default function Entries({ projectId, localeCode }: Props) {
    const { authorizedFetch } = useAuth();
    const localesQuery = useSuspenseQuery({
        queryKey: ["entries-query", localeCode],
        retry: false,
        staleTime: 1,
        queryFn: async (): Promise<EntryModel[]> => {
            console.log("loading projects");
            const fetchedlocales: EntryModel[] = await authorizedFetch(new Request(API_URL + "/projects/" + projectId + "/entries/" + localeCode));
            return fetchedlocales;
        }
    })

    const locales = localesQuery.data;

    return <>
        <ul>
            {locales.map(l =>
            (<li key={l.id}>
                {l.key} : {l.value}
            </li>))}
        </ul>
    </>
}

import { useSuspenseQuery } from "@tanstack/react-query";
import { useAuth } from "../auth/AuthProvider"
import { API_URL } from "../services/api";
import { Link } from "react-router";
import { ProjectModel } from "../services/model";

export default function Projects() {
    const { authorizedFetch } = useAuth();
    const query = useSuspenseQuery({
        queryKey: ["projects-query"],
        retry: false,
        staleTime: 1000,
        queryFn: async (): Promise<ProjectModel[]> => {
            console.log("loading projects");
            const fetchedProjects: ProjectModel[] = await authorizedFetch(new Request(API_URL + "/projects"));
            return fetchedProjects;
        }
    })

    const projects = query.data;

    return <>
        <ul>
            {projects.map((p) => (
                <li key={p.id}>
                    <Link to={`/${p.id}`} state={p}>
                        <span>{p.name}</span>
                        <span>({p.id})</span>
                    </Link>
                </li>
            ))}
        </ul>
    </>
}

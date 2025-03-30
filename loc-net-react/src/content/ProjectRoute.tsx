import { useLocation } from "react-router";
import { GenericError } from "../services/api";
import { ProjectModel } from "../services/model";
import Project from "./Project";

export default function ProjectRoute() {
    const loc = useLocation();
    if (!(loc.state as ProjectModel))
        throw GenericError;
    const project: ProjectModel = loc.state
    return <Project project={project} />
}

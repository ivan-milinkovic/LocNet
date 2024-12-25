using System.Net;
using Microsoft.EntityFrameworkCore;

namespace LocNet.Exceptions;

public class LocExceptionMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (ProjectUserNotFoundException)
        {
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
        }
        catch (UserIdNotFoundException)
        {
            context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
        }
        catch (EntityAlreadyExistsException)
        {
            context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
        }
        catch (DbUpdateException)
        {
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
        }
    }
}

using MyWebApiApp.Models;

namespace MyWebApiApp.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(AppUser user);
    }
}

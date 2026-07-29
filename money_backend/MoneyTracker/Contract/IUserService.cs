using MoneyTracker.Models;

namespace MoneyTracker.Contract
{
    public interface IUserService
    {
        Task<string> RegisterUserAsync(string Username, string Email, string Password);
        Task<LoginResponse> LoginUserAsync(string Email, string Password);
    }
}

using Microsoft.AspNetCore.Mvc;
using MoneyTracker.Contract;

namespace MoneyTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class AuthController : ControllerBase
    {

        private readonly IUserService _userService;

        public AuthController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(string Username, string Email, string Password)
        {
            var rsl = await _userService.RegisterUserAsync(Username, Email, Password);
            return Ok(rsl);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(string Email, string Password)
        {
            var lsl = await _userService.LoginUserAsync(Email, Password);
            return Ok(lsl);
        }

    }
}

using Microsoft.AspNetCore.Mvc;
using MoneyTracker.Contract;
using MoneyTracker.Models;
using MoneyTracker.Service;

namespace MoneyTracker.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LimitController : ControllerBase
    {
        private readonly ILimitService _limitService;

        public LimitController(ILimitService limitService)
        {
            _limitService = limitService;
        }

        [HttpPost("set")]

        public async Task<IActionResult> SetLimit(int userid, DateTime date, decimal limitamount)
        {
            await _limitService.SetDailyLimitAsync(userid,date,limitamount);
            return Ok(new { message = "Limit set successfully." });
        }
    }


}

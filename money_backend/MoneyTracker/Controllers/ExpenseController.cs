using Microsoft.AspNetCore.Mvc;
using MoneyTracker.Contract;

namespace MoneyTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]

    public class ExpenseController : ControllerBase
    {

        private readonly IExpenseService _expenseService;

        public ExpenseController(IExpenseService expenseService)
        {
            _expenseService = expenseService;
        }

        [HttpPost("add")]
        public async Task<IActionResult> Add(int userid, DateTime date, decimal amount, string category, string description)
        {
            var rsl = await _expenseService.AddExpense(userid, date, amount, category, description);
            return Ok(rsl);
        }

        [HttpPost("update")]
        public async Task<IActionResult> Update(int userid,int expenseid, DateTime date, decimal amount, string category, string description)
        {
            var rsl = await _expenseService.UpdateExpense(userid,expenseid, date, amount, category, description);
            return Ok(rsl);
        }

        [HttpPost("delete")]
        public async Task<IActionResult> Delete(int expenseid)
        {
            var rsl = await _expenseService.DeleteExpense(expenseid);
            return Ok(rsl);
        }

        [HttpPost("GetByUserId")]
        public async Task<IActionResult> byUserId(int userid)
        {
            var rsl = await _expenseService.GetByUserIdAsync(userid);
            return Ok(rsl);
        }

        [HttpPost("GetByExpenseId")]
        public async Task<IActionResult> byExpenseId(int expenseid)
        {
            var rsl = await _expenseService.GetByExpenseIdAsync(expenseid);
            return Ok(rsl);
        }
    }
}

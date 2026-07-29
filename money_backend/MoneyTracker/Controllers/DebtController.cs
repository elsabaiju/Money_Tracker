using Microsoft.AspNetCore.Mvc;
using MoneyTracker.Contract;
using Moneytracker.Models;
using System;
using System.Threading.Tasks;

namespace MoneyTracker.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DebtController : ControllerBase
    {
        private readonly IDebtService _debtService;

        public DebtController(IDebtService debtService)
        {
            _debtService = debtService;
        }

        [HttpPost("GetFilteredDebts")]
        public async Task<IActionResult> GetFilteredDebtsAsync(
            [FromQuery] int userId,
            [FromQuery] string? name,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate)
        {
            var debts = await _debtService.GetFilteredDebtsAsync(
                userId,
                name,
                fromDate,
                toDate
            );
            return Ok(debts);
        }

        [HttpPost("getByUserId")]
        public async Task<IActionResult> GetByUserId([FromQuery] int userid)
        {
            var debts = await _debtService.GetByUserIdAsync(userid);
            return Ok(debts);
        }
        [HttpPost("byuserid")]
        public async Task<IEnumerable<DebtModel>> GetDebtsByUserId([FromQuery] int userId)
        {
            return await _debtService.GetByUserIdAsync(userId);
        }

        [HttpPost("getByDebtId")]
        public async Task<IActionResult> GetByDebtId([FromQuery] int debtid)
        {
            var debts = await _debtService.GetByDebitIdAsync(debtid);
            return Ok(debts);
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateDebt(
            [FromQuery] int userid,
            [FromQuery] DateTime date,
            [FromQuery] double amount,
            [FromQuery] string category,
            [FromQuery] string name,
            [FromQuery] string description)
        {
            var debt = new DebtModel
            {
                UserId = userid,
                Date = date,
                Amount = (decimal)amount,
                Category = category,
                Name = name,
                Description = description
            };

            await _debtService.CreateDebtAsync(debt);
            return Ok(new { message = "Debt created successfully", debtId = debt.DebtId });
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateDebt(
            [FromQuery] int debtid,
            [FromQuery] int userid,
            [FromQuery] DateTime date,
            [FromQuery] double amount,
            [FromQuery] string category,
            [FromQuery] string name,
            [FromQuery] string description)
        {
            var debt = new DebtModel
            {
                DebtId = debtid,
                UserId = userid,
                Date = date,
                Amount = (decimal)amount,
                Category = category,
                Name = name,
                Description = description
            };

            await _debtService.UpdateDebtAsync(debt);
            return Ok(new { message = "Debt updated successfully" });
        }

        [HttpPost("delete")]
        public async Task<IActionResult> DeleteDebt([FromQuery] DateTime date, [FromQuery] string name)
        {
            await _debtService.DeleteDebtAsync(date, name);
            return Ok(new { message = "Debt deleted successfully" });
        }
    }
}

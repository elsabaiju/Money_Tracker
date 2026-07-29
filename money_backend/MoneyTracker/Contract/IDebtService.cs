using Moneytracker.Models;
using MoneyTracker.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MoneyTracker.Contract
{
    public interface IDebtService
    {
        Task<bool> CreateDebtAsync(DebtModel debt);
        Task<bool> UpdateDebtAsync(DebtModel debt);
        Task<bool> DeleteDebtAsync(DateTime date, string name);

        Task<IEnumerable<DebtModel>> GetByUserIdAsync(int userid);
        Task<IEnumerable<DebtModel>> GetByDebitIdAsync(int debtid);


        Task<IEnumerable<DebtModel>> GetFilteredDebtsAsync(
       int userId,
       string? name,
       DateTime? fromDate,
       DateTime? toDate
   );
    }
}
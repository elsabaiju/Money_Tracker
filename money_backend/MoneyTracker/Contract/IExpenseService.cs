using MoneyTracker.Models;

namespace MoneyTracker.Contract
{
    public interface IExpenseService
    {
        Task<string> AddExpense(int userid, DateTime date, decimal amount, string category, string description);
        Task<string> UpdateExpense(int userid, int expenseid, DateTime date, decimal amount, string category, string description);
        Task<string> DeleteExpense(int expenseid);
        Task<IEnumerable<Expenses>> GetByUserIdAsync(int userid);
        Task<Expenses> GetByExpenseIdAsync(int expenseid);



    }
}

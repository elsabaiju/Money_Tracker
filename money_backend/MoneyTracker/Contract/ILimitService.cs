using MoneyTracker.Models;

namespace MoneyTracker.Contract
{
    public interface ILimitService
    {
        Task<Limit> SetDailyLimitAsync(int UserId, DateTime Date, decimal LimitAmount);
    }
}

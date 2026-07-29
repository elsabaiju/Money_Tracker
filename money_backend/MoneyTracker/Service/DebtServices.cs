using Dapper;
using Moneytracker.Models;
using MoneyTracker.Contract;
using MoneyTracker.Models;
using System.Data;
using System.Data.SqlClient;

namespace MoneyTracker.Service
{
    public class DebtService : IDebtService
    {
        private readonly IDbConnection _dbConnection;

        public DebtService(IDbConnection dbConnection)
        {
            _dbConnection = dbConnection;
        }

        public async Task<IEnumerable<DebtModel>> GetFilteredDebtsAsync(
            int userId,
            string? name,
            DateTime? fromDate,
            DateTime? toDate)
        {
            var sql = "SELECT * FROM debts WHERE UserId = @UserId";
            var parameters = new DynamicParameters();
            parameters.Add("UserId", userId);

            if (!string.IsNullOrEmpty(name))
            {
                sql += " AND Name = @Name";
                parameters.Add("Name", name);
            }

            if (fromDate.HasValue && toDate.HasValue)
            {
                sql += " AND Deadline BETWEEN @FromDate AND @ToDate";
                parameters.Add("FromDate", fromDate);
                parameters.Add("ToDate", toDate?.AddDays(1));
            }

            return await _dbConnection.QueryAsync<DebtModel>(sql, parameters);
        }

        // ----------- PATCHED METHOD: SAFE DATE HANDLING -----------
        public async Task<bool> CreateDebtAsync(DebtModel debt)
        {
            var minSqlDate = (DateTime)System.Data.SqlTypes.SqlDateTime.MinValue;

            // PATCH: Validate and fix bad dates before inserting
            if (debt.Date < minSqlDate)
                debt.Date = DateTime.Today;

            if (debt.Deadline < minSqlDate)
                debt.Deadline = DateTime.Today.AddDays(30); // or any safe default

            var sql = @"INSERT INTO debts (UserId, Date, Amount, Category, Deadline, Name, Description)
                        VALUES (@UserId, @Date, @Amount, @Category, @Deadline, @Name, @Description)";

            var result = await _dbConnection.ExecuteAsync(sql, debt);
            return result > 0;
        }

        // ----------- PATCHED METHOD: SAFE DATE HANDLING -----------
        public async Task<bool> UpdateDebtAsync(DebtModel debt)
        {
            var minSqlDate = (DateTime)System.Data.SqlTypes.SqlDateTime.MinValue;

            // PATCH: Validate and fix bad dates before updating
            if (debt.Date < minSqlDate)
                debt.Date = DateTime.Today;

            if (debt.Deadline < minSqlDate)
                debt.Deadline = DateTime.Today.AddDays(30);

            var sql = @"UPDATE debts SET 
                        UserId = @UserId,
                        Date = @Date, 
                        Amount = @Amount, 
                        Category = @Category, 
                        Deadline = @Deadline, 
                        Name = @Name, 
                        Description = @Description
                        WHERE DebtId = @DebtId";

            var result = await _dbConnection.ExecuteAsync(sql, debt);
            return result > 0;
        }




        public async Task<bool> DeleteDebtAsync(DateTime date, string name)
        {
            var sql = "DELETE FROM debts WHERE Date = @Date AND Name = @Name";
            var result = await _dbConnection.ExecuteAsync(sql, new { Date = date, Name = name });
            return result > 0;
        }

        public async Task<IEnumerable<DebtModel>> GetByUserIdAsync(int userid)
        {
            var sql = "SELECT * FROM debts WHERE UserId = @UserId";
            return await _dbConnection.QueryAsync<DebtModel>(sql, new { UserId = userid });
        }

        public async Task<IEnumerable<DebtModel>> GetByDebitIdAsync(int debtid)
        {
            var sql = "SELECT * FROM debts WHERE DebtId = @DebtId";
            return await _dbConnection.QueryAsync<DebtModel>(sql, new { DebtId = debtid });
        }
    }
}

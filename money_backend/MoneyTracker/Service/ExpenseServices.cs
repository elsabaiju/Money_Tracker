using Dapper;
using Microsoft.Data.SqlClient;
using MoneyTracker.Contract;
using MoneyTracker.Models;
using System.Data;
using System.Threading.Tasks;

namespace MoneyTracker.Service
{
    public class ExpenseServices : IExpenseService
    {
        private readonly IDbConnection _dbConnection;
        public ExpenseServices(IDbConnection dbConnection)
        {
            _dbConnection = dbConnection;
        }

        public async Task<string> AddExpense(int userid, DateTime date, decimal amount, string category, string description)
        {
            var add = await _dbConnection.ExecuteAsync("Insert into expenses(userid,date,amount,category,description) values(@userid,@date,@amount,@category,@description)",
                new { userid = userid, date, amount, category, description });


            return add > 0 ? "Expense added" : "Failed to add";
        }


        public async Task<string> UpdateExpense(int userid, int expenseid, DateTime date, decimal amount, string category, string description)
        {
            var sql = "UPDATE expenses SET " +
                  "date = @date, " +
                  "amount = @amount, " +
                  "category = @category, " +
                  "description = @description " +
                  "WHERE userid = @userid AND expenseid = @expenseid";

            var update = await _dbConnection.ExecuteAsync(sql, new
            {
                userid = userid,
                expenseid = expenseid,
                date = date,
                amount = amount,
                category = category,
                description = description
            });

        return update > 0 ? "Updated" : "Failed to update";
        }


        public async Task<string> DeleteExpense(int expenseid)
        {
            {
                var delete = await _dbConnection.ExecuteAsync(
                "DELETE FROM expenses WHERE expenseid = @expenseid",
                new { expenseid = expenseid }
            );

                return delete > 0 ? "Deleted successfully" : "Failed to delete";
            }
        }

        public async Task<IEnumerable<Expenses>> GetByUserIdAsync(int userid)
        {
            var expenses = await _dbConnection.QueryAsync<Expenses>(
                "SELECT * FROM expenses WHERE userid = @userid", new { userid = userid });

            return expenses;
        }

        public async Task<Expenses> GetByExpenseIdAsync(int expenseid)
        {
            var expense = await _dbConnection.QueryFirstOrDefaultAsync<Expenses>(
                "SELECT * FROM expenses WHERE expenseid = @expenseid", new { expenseid = expenseid });

            if (expense == null)
                throw new Exception("Expense not found");

            return expense;
        }
    }
}

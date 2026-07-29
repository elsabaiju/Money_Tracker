using Dapper;
using MoneyTracker.Contract;
using MoneyTracker.Models;
using System.Data;

namespace MoneyTracker.Service
{
    public class LimitService : ILimitService
    {
        private readonly IDbConnection _db;

        public LimitService(IDbConnection dbConnection)
        {
            _db = dbConnection;
        }

        public async Task<Limit> SetDailyLimitAsync(int userid,DateTime date,decimal limitamount)
        {
            var mergeSql = @"
            MERGE INTO limits AS target
            USING (SELECT @userid AS userid, @date AS date) AS source
            ON target.userid = source.userid AND target.date = source.date
            WHEN MATCHED THEN
                UPDATE SET limitamount = @limitamount
            WHEN NOT MATCHED THEN
                INSERT (userid, date, limitamount)
                VALUES (@userid, @date, @limitamount);";

            await _db.ExecuteAsync(mergeSql, new
            {
                userid,
                date,
                limitamount
            });

            var selectSql = "SELECT * FROM limits WHERE userid = @userid AND date = @date";
            var limit = await _db.QuerySingleOrDefaultAsync<Limit>(selectSql, new
            {
                userid,
                date
            });

            // Ensure a value is always returned
            return limit ?? new Limit
            {
                UserId = userid,
                Date = date,
                LimitAmount = limitamount
            };
        }

    }
}


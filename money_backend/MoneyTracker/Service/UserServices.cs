using System.Data;
using System.Reflection.Metadata.Ecma335;
using Dapper;
using Microsoft.AspNetCore.Identity;
using MoneyTracker.Contract;
using MoneyTracker.Models;

namespace MoneyTracker.Service
{
    public class UserServices : IUserService
    {
        private readonly IDbConnection _dbConnection;

        public UserServices(IDbConnection dbConnection)
        {
            _dbConnection = dbConnection;
        }

        public async Task<string> RegisterUserAsync(string username, string Email, string password)
        {
            var existingUser = await _dbConnection.QueryFirstOrDefaultAsync<Users>(
                "SELECT * FROM users WHERE email = @email", new { email = Email });

            if (existingUser != null)
            {
                return "User already exists";
            }

            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

            var result = await _dbConnection.ExecuteAsync(
                "INSERT INTO users (username, email, password) VALUES (@username, @email, @password)",
                new { username = username, email = Email, password = hashedPassword });

            return result > 0 ? "User registered successfully" : "User registration failed";
        }
        public async Task<LoginResponse> LoginUserAsync(string Email, string password)
        {
            var existingUser = await _dbConnection.QueryFirstOrDefaultAsync<Users>(
                "SELECT * FROM users WHERE email = @email", new { email = Email });

            if (existingUser == null)
            {
                return null;
            }

            var deCrypt = BCrypt.Net.BCrypt.Verify(password, existingUser.Password);


            if (deCrypt)
            {
                return new LoginResponse
                {
                    message = "success", // ✔ correct spelling
                    userId = existingUser.Userid, // ✔ correct ID
                    username = existingUser.Username
                };
            }
            else
            {
                return new LoginResponse
                {
                    message = "Login failed",
                    userId = 0,
                    username = ""
                };
            }

        }
    }
}

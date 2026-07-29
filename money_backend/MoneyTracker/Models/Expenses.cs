namespace MoneyTracker.Models
{
    public class Expenses
    {
        public int expenseid { get; set; }
        public int userid { get; set; }
        public DateTime date { get; set; }
        public decimal amount { get; set; }
        public string category { get; set; }
        public string description { get; set; }
    }
}

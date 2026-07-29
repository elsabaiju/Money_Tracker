namespace Moneytracker.Models
{
    public class DebtModel
    {
        public int DebtId { get; set; }
        public int UserId { get; set; }
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
        public string Category { get; set; }
        public DateTime Deadline { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;
using ContactManager.Data;

namespace ContactManager.Pages
{
    public class ContactsModel : PageModel
    {
        private readonly MyOptions _options;
        private readonly ContactDbContext _contactDbContext;
        public List<Contact> Contacts { get; set; } = new List<Contact>();
        [BindProperty]
        public string NewContactFirstname { get; set; }
        [BindProperty]
        public string NewContactLastname { get; set; }
        [BindProperty]
        public string NewContactPhone { get; set; }
        [BindProperty]
        public string NewContactAddress { get; set; }


        public ContactsModel(IOptions<MyOptions> myOptions,ContactDbContext contactDbContext)
        {
            _options = myOptions.Value;
            _contactDbContext = contactDbContext;
        }
        public async Task<IActionResult> OnGet()
        {
           Contacts = _contactDbContext.Contact.ToList();
            return Page();
        }
        public async Task<IActionResult> OnPost()
        {
            if (ModelState.IsValid)
            {
                var newContact = new Contact
                {
                    FirstName = NewContactFirstname,
                    LastName = NewContactLastname,
                    Phone = NewContactPhone,
                    Address = NewContactAddress
                };
                var result = await _contactDbContext.Contact.AddAsync(newContact);
                // var result = await _contactDbContext.AddAsync<Contact>(newContact);
                await _contactDbContext.SaveChangesAsync();
            }

            return Page();
        }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;

namespace ContactManager.Pages
{
    public class ContactsModel : PageModel
    {
        private readonly MyOptions _options;

        public ContactsModel(IOptions<MyOptions> myOptions)
        {
            _options = myOptions.Value;
        }
        public void OnGet()
        {
        }
    }
}
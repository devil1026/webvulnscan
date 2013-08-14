from ..log import vulnerability

from ..client import Client


class CsrfAttack(object):
    name = "csrf"

    def __init__(self, page):
        self.target_page = page
        self.client = Client()

    def fill_entries(self, form, filter_type=None):
        for form_input in form.get_inputs():
            input_name = form_input.get_name
            input_value = form_input.guess_value()
            input_type = form_input.get_type

            if filter_type is None:
                yield input_name, input_value
            else:
                if input_type != filter_type:
                    yield input_name, input_value

    def try_csrf(self, form):
        # First, we send a valid request.
        valid_parameters = {x: y for x, y in self.fill_entries(form)}
        form.send(self.client, valid_parameters)

        # Now, we supress every thing that looks like a token.
        broken_parameters = {x: y for x, y in
                             self.fill_entries(form, "hidden")}
        response = form.send(self.client, broken_parameters)

        # Check if Request passed
        if response.status_code == 200:
            # Request passed, CSRF found...
            vulnerability("Vulnerability: CSRF under " + form.action)

    def run(self, client=None):
        if client is not None:
            self.client = client

        for form in self.target_page.get_forms():
            self.try_csrf(form)

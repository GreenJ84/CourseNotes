# Introduction

People are reminded about computer security risks almost every day. Being safe online involves many things. People can be safe in what they do with computers. For example, you don't want to visit websites that may cause you harm. Users also want to be safe in how they do the various activities on computers. For example, you don't want to store passwords in a file that anyone can read.

In this module, you learn how computer systems are built to keep people safe. By seeing how these safety systems work, people can make better use of them. Developers who program computers need to understand these systems well so they can use the best tools possible.

In this module you explore the following topics around the concept of Identity - How people are recognized in a computer system:

How computer systems recognize people
How computers know what you can and can't do
The blockchain and security
Hackers: How people work to make computers unsafe and what people can do about it.
The importance of good software code
Passwords, the good and the bad
Two-factor authentication as a second line of defense
How biometrics are even better
How hackers use social engineering to steal data

Safety is something for which every computer user needs to be responsible. But programmers and engineers have a big role to play in keeping people safe. In this module you explore how both, working together, can make a safer computing experience for everyone.

## Explore identity

Most people who have used a computer know about passwords. People rely on passwords to prevent others from getting to their stuff. Computer systems use passwords to know that you are who you say you are. There are other ways we can access computers too. We can use our fingerprints or our face. All these ways help keep us and our stuff safe.

### Knowing Who You Are

All these methods are ways computers use to verify a person's identity. A valid identity tells a computer that the user is allowed to use it. Each of these ways verifies them because, ideally, only they know their password. Their fingerprint only belongs to them. Their face is, well, their face. In the language of computer science, this is called authentication.

Suppose you set up an account on a computer system (like a streaming media service, for example). When you sign in for the first time, you create a relationship with the system. You create a username and password, telling the computer you're someone unique. If someone tries to sign in as you, they need to know your password along with your username. The combination is unique on that streaming service and should be known only to you.

#### A Clubhouse Example

Imagine that as a child, you created a club. You and a group of friends were in this club. You had a clubhouse. This was a place you'd meet and tell stories or eat snacks.

In this club, you made a "secret password" so only people with the password could get into the clubhouse. You'd spend a good deal of time trying to come up with the perfect (and usually funny) password. You'd whisper the secret password to each other and promised not to tell anyone. The next time one of you came to the clubhouse, someone at the entrance would ask for the password before they'd grant entry.

In this case, the password wasn't used to make sure only certain people could get in. You and your friends all knew each other. Rather, you used the password to keep people out. If a parent, guardian, or stranger tried to get into your secret club, you could ask, "What's the password?" If they didn't know it, they couldn't get in.

Passwords and other identification tools do both things. They tell the system who should be allowed in. But they also keep all others out.

### What Can I Do?

Identity is only one part of security. Once you've gotten into a system, it may be important to prevent certain types of activity. For example, a family who shares a computer may give everyone access to a movie service. But they may want to restrict the kids from watching movies with a certain rating. Everyone can get in. Only the adults can watch all the movies. Computer scientists call this authorization.

Modern computer systems are designed so administrators can authorize people based on roles. Everyone with an "owner" role, for example, may have access to everything. People with a "member" role will have limited access. Members may have access to some files and can only do a limited number of things.

Going back to our clubhouse example, suppose the club had bylaws. The bylaws tell the members what the club is about and the rules everyone has to follow. The bylaws may say that only the president and vice president can vote on changes to the bylaws. Everyone else just gets to follow the rules. This may not be a great club, but this governmental system does show how authorization works.

Without authentication, anyone on the internet would be able to access any computer system. Without authorization, it wouldn't be possible to restrict access to certain data, files, or services once a person has access to a system. By using both together, computer administrators have powerful tools to keep people and assets safe.

## Research cloud identity

Making a single computer secure is hard enough. Making files and computers on the internet secure is really difficult. Still, there are many ways to keep people secure on the internet. Let's look at a few of them.

### Single sign-on

In the cloud, many systems talk to each other. Let's suppose you're attending a school and sign into their computer system. Your school may provide access to a library that is a part of another school. You can have access to this library but would need to get to it securely.

One way to access this other library is to sign in to it separately. You would have a sign-in for your school and another sign-in for the library. This is secure, but it has problems. First, it means you have to set up two accounts. You'll have to remember the usernames and passwords for both. Second, the library may only want students at your (and other) schools to have access. In order to create a library account, you'll have to verify you're attending the school. This can take time and energy and can be costly for both the school and the library.

It would be easier if the library could just "trust" the users that sign in to the school's system, wouldn't it? This is possible with modern tools. With a tool called single sign-on, the school can send students to the library and automatically sign them in. The library knows that anyone who was sent to them by the school is verified (authenticated). Of course, the student has to sign in to the school first. But once that's done, they can be "passed through" to the library.

### Trusted sources

Another way to make access easier but just as secure is for one organization to trust another because the second has done all the work to validate the user. You may have signed in to a movie service or online shop using your social media username and password. In this case, the shop trusts that the social media company checked you out and so trusts signed-in users that the social media company sends them.

This is how it works. Suppose you go to an online shop (we'll call it 'Munson's Pickles and Preserves Farm') and need to create an account. One of the options for creating a valid account is to use your social media (say LinkedIn) sign-in. When you choose this option, you're taken to LinkedIn to sign in. Once you successfully sign in, LinkedIn tells Munson's Pickles and Preserves Farm that you're a valid user and they should trust you. LinkedIn sends Munson's Pickles and Preserves Farm information that they can use to trust you now and in the future.

This approach saves Munson's Pickles and Preserves Farm from having to verify you since they can just trust LinkedIn. It also means you don't have to create a new sign-in. You just use your LinkedIn username and password for both LinkedIn and Munson's Pickles and Preserves Farm.

## Investigate two factor security

Passwords have been used for decades. With passwords, the information and systems the password protects is only as secure as the actual password. A password like 123abc is easy to remember (which is why people use it), but it's also easy to guess. Easy to guess or crack passwords are insecure. People also use birthdays and favorite colors for passwords. These aren't secure passwords either. So passwords have gotten a lot of criticism.

Using fingerprints and faces to authenticate a user is a lot more secure. These methods are being used more. And there's another way getting more popular.

### The Phone in Your Pocket

Two reasons why a fingerprint is secure and easy to use are:

It's hard to copy
People always have it with them

Computer scientists realized there's another thing many people carry around that fits the same bill. When mobile phones became common, scientists figured out a way to use them like fingerprints. Since most people treat their mobile phones like their wallet or purse, they tend to be carefully guarded. People also tend to have them everywhere they go. So using them as a security device became an option.

When you set up an account at a streaming service or a bank, you may be asked to provide your mobile phone number. The bank may then send you a text message with a code. You'll be asked to enter that code on a form to verify you own the phone. Once you do, the bank can then use that same number in the future to make sure that the person who set up the account is the one accessing it.

The bank may send you a code each time you sign in. They'll ask for the new code in addition to your password. You now have two items of information to give them. When you provide two pieces of information, it's called two-factor authentication (or 2FA).

### Other 2FA Options

Using a mobile phone is just one way of validating you. A bank could also call a landline and ask you to press numbers to verify who you are. If you don't have a mobile phone, companies can send you an email with a code, and you enter the code from the email.

There are also apps called "authenticators" that either generate a code or ask you to pick a number from a list to verify your identity. The app works similarly to the text message in that you have to first show that the phone that is using the app is yours. Once you verify it's your phone, some authenticators ask if you want to approve the sign-in with a simple yes or no.

Passwords can be combined with any other method of verification (like a fingerprint). Any combination of verification methods counts as 2FA. These days though, the mobile device seems to be the most popular way. Using a code in a text message or an authenticator is very common and gives a level of security that goes well beyond passwords alone.

## Inspect biometrics

The term "biometric" refers to using a person's body (their biology) as a security tool. One example is a fingerprint. Fingerprints are unique. Law enforcement uses them to identify people because they're hard to copy. Computer scientists have developed tools that can read fingerprints. They can use them to secure computers.

### Beyond Passwords

Passwords used with another tool like a mobile phone are pretty secure. Many computer scientists believe biometrics are even stronger. A lot of devices now use biometrics alone to sign in a user. On your mobile device, you may rely on face ID or a fingerprint to get access.

Modern tools that use this type of identity are advanced. Using a face for ID involves a number of things. For example, these tools may measure the distance between the center of their eyes. It also may examine the shape of their mouth. The size of their forehead may play a factor. All of these pieces of data are used together to identify them.

The use of a fingerprint or face for identification is so strong that it can be used all by itself. Door lock makers, for example, are putting fingerprint readers on their locks. You can use your fingerprint alone to gain access to your house.

### The Future of Biometrics and Programming

As biometric systems get more advanced, using voice or patterns within the eye may be a way to sign in. Computer programmers may have access to these security tools to use in their software. Some companies are making these tools available now.

There are some concerns about the use of biometrics. Privacy is one. A public camera that is able to identify people without their knowledge may violate privacy. Lawmakers are working to ensure that this type of identity is used safely.

Any programmer that uses these tools should let the user know that they're using them. And data should be stored carefully. Users should always have the chance to delete any biometric data. Users also should have the option to sign in to their devices in ways other than using biometrics.

## Understand bad actors

There always seem to be people who want to use good things for bad ends. Computers and the internet have a lot of power for good. Unfortunately, some people want to use that power to cause harm.

This is partly why security is so important. But it also means computer programmers have to take extra care to build security into their systems. Security is something we all have to focus on.

### Phishing

Phishing is when someone tries to get personal data by hiding who they really are. A person may visit a site or get an email that looks real. For example, you may get an email from your favorite shopping site. It may have the company's logo and all the details at the bottom that look like it came from the store. The mail says that it's time for you to update your account information. It provides a link for you to do just that.

When you click the link, it takes you to a web page that looks like your shopping site. But it isn't. It has been made to look like it, but it's just there to get your information. This is called a phishing attack.

There are many ways you can protect yourself from phishing attacks. One way is to check all links before you click them. Most modern desktop browsers and email tools help you with this. If you rest your mouse over a link and wait for a second or two, the tool will show you the actual link. If the text you see says it takes you to www.relecloud.com, but the actual link is to some website you don't know, be careful!

The link exposure tool is one way programmers have developed to help protect users. Many computer companies also do background checks on web links. They keep databases of links that can cause harm. When you try to click a potentially bad link, the software can warn you.

### Hacking

Hackers come in many shapes and sizes. There are "black hat" hackers that are after money or to cause harm. There are "white hat" hackers that can break into systems like any other hacker but have noble goals (like exposing weaknesses). There even are gray hat hackers that sometimes break the rules but generally have good intentions.

The black hats are the ones to be most concerned about. Hackers have the ability to break into computer systems by violating security. They may use tools to test thousands of passwords a minute until they find one that works. They write code that can be injected into computers to gain access. They also can write code in programs that seem innocent (like a game) but are designed to steal information.

Many of the security tools you see today are designed to prevent hacking. Many of them work well, but hackers can still find a way to work around them. Being safe involves trusting software from reputable companies. But it also means being vigilant and aware of what you're doing.

### Programming for Safety

Becoming a good programmer means partly designing programs with security in mind. There are many "best practices" programmers use to do this. Many of the modern tools programmers use also help make them aware of potential issues. Finally, lots of testing can help catch bugs and issues that leave a program open to hackers.

## Summary

In this module you explored the basics of computer and cloud security. You looked at how computers authorize people and give them permissions to do certain things. You explored ways that people can let computers know who they are. You also looked at how people try to make computers unsafe and what can be done about it.

Specifically, in this module you explored the following:

Authentication: the process by which a computer lets a person access it
Authorization: the process by which a computer lets a user do certain things
Single sign on: this lets a user sign in to one service or site and have their authentication pass through to another
Two-factor authentication: another layer of security that keeps a computer safer
Biometrics: as the way to use face, fingerprint, or voice to authenticate a user
Hackers and ways to prevent people from doing bad things on computer systems

With these topics, you discovered the basics of computer security. Programmers need to be aware of each of these. Security should be at the core of all programming. These topics give you a good place to start.
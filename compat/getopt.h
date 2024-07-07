#ifndef COMPAT_GETOPT_H
#define COMPAT_GETOPT_H

#ifdef _WINDOWS_COMPAT

#include <string.h>

extern char *optarg;
extern int optind, opterr, optopt;

#ifndef COMPAT_GETOPT_INTERNAL
extern int getopt(int argc, char *const argv[], const char *optstring);
#else
char *optarg = NULL;
int optind = 1;
int opterr = 1;
int optopt = '?';

int getopt(int argc, char *const argv[], const char *optstring) {
    static int optpos = 1;

    if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0') {
        return -1;
    }

    int opt = argv[optind][optpos++];
    const char *p = strchr(optstring, opt);

    if (opt == ':' || p == NULL) {
        if (opterr && *optstring != ':') {
            fprintf(stderr, "%s: invalid option -- '%c'\n", argv[0], opt);
        }
        optopt = opt;
        return '?';
    }

    if (p[1] == ':') {
        if (argv[optind][optpos] != '\0') {
            optarg = &argv[optind][optpos];
            optind++;
            optpos = 1;
        } else if (++optind >= argc) {
            if (opterr && *optstring != ':') {
                fprintf(stderr, "%s: option requires an argument -- '%c'\n", argv[0], opt);
            }
            optopt = opt;
            return *optstring == ':' ? ':' : '?';
        } else {
            optarg = argv[optind++];
        }
    } else {
        if (argv[optind][optpos] == '\0') {
            optind++;
            optpos = 1;
        }
    }

    return opt;
}
#endif // COMPAT_GETOPT_INTERNAL

#else
#include <getopt.h>
#endif // _WIN32

#endif // COMPAT_GETOPT_H

// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * livepatch-sample.c - Kernel Live Patching Sample Module
 *
 * Copyright (C) 2014 Seth Jennings <sjenning@redhat.com>
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>

// INCLUDE HELL

#include <linux/blk-mq.h>
#include <linux/delay.h>
struct blk_mq_tags {
	unsigned int nr_tags;
	unsigned int nr_reserved_tags;

	atomic_t active_queues;

	struct sbitmap_queue *bitmap_tags;
	struct sbitmap_queue *breserved_tags;

	struct sbitmap_queue __bitmap_tags;
	struct sbitmap_queue __breserved_tags;

	struct request **rqs;
	struct request **static_rqs;
	struct list_head page_list;

	/*
	 * used to clear request reference in rqs[] before freeing one
	 * request pool
	 */
	spinlock_t lock;
};
// INCLUDE HELL END
static struct request *patch0_blk_mq_find_and_get_req(struct blk_mq_tags *tags,
		unsigned int bitnr)
{
	struct request *rq;
	unsigned long flags;

	spin_lock_irqsave(&tags->lock, flags);
	rq = tags->rqs[bitnr];
	if (!rq || rq->tag != bitnr || !refcount_inc_not_zero(&rq->ref))
		rq = NULL;
	spin_unlock_irqrestore(&tags->lock, flags);
	return rq;
}

static struct klp_func funcs[] = {
	{
		.old_name = "blk_mq_find_and_get_req",
		.new_func = patch0_blk_mq_find_and_get_req,
	}, { }
};

static struct klp_object objs[] = {
	{
		/* name being NULL means vmlinux */
		.funcs = funcs,
	}, { }
};

static struct klp_patch patch = {
	.mod = THIS_MODULE,
	.objs = objs,
};

static int livepatch_init(void)
{
	return klp_enable_patch(&patch);
}

static void livepatch_exit(void)
{
}

module_init(livepatch_init);
module_exit(livepatch_exit);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
